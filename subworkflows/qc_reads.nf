include { compute_bases_genome                            } from '../modules/compute_bases_genome.nf'
include { fastqc_summary       as fastqc_summary_prealign } from '../modules/fastqc_summary'
include { fastqc_summary       as fastqc_summary_raw      } from '../modules/fastqc_summary'
include { fastqc               as fastqc_prealign         } from '../modules/fastqc.nf'
include { fastqc               as fastqc_raw              } from '../modules/fastqc.nf'
include { multiqc              as multiqc_reads           } from '../modules/multiqc.nf'


workflow QC_Reads {
    take:
        reads_raw
        reads_prealign
        trim_log
        genome_index

    main:
        // run FastQC for raw and prealigned reads
        fastqc_raw(reads_raw)
        fastqc_prealign(reads_prealign)

        compute_bases_genome(genome_index)
        // Construct channel of number bases in genome as a Long value
        ch_baseCountGenome = compute_bases_genome.out.bases
            .map { bases -> return Long.valueOf(bases) }

        /*
            Compute read depth of raw reads
        */
        // Count bases in raw reads at sequence result level
        fastqc_summary_raw(fastqc_raw.out.zip)
        // Compute sequencing depth for raw reads at sample level
        // Sequencing depth = Count bases in reads for a sample / count bases in the reference genome
        // Count bases in reads for sample = Sum of base count each sequence result belonging to sample
        ch_sequencingDepthRaw = computeSequencingDepth(
            fastqc_summary_raw.out.fastqcSummary,
            ch_baseCountGenome,
            "raw"
        )

        /*
            Compute read depth of prealign reads
        */
        // Count bases in prealign reads at sequence result level
        fastqc_summary_prealign(fastqc_prealign.out.zip)
        // Compute sequencing depth for prealign reads at sample level
        // Sequencing depth = Count bases in reads for a sample / count bases in the reference genome
        // Count bases in reads for sample = Sum of base count each sequence result belonging to sample
        ch_sequencingDepthPrealign = computeSequencingDepth(
            fastqc_summary_prealign.out.fastqcSummary,
            ch_baseCountGenome,
            "prealign"
        )

        /*
            Run MultiQC for reads QC metrics
        */
        // concatenate and collect various QC metrics into one channel sorted by file name
        ch_multiqcReads = Channel.empty()
            .mix(
                fastqc_raw.out.zip.flatMap { metadata, r1FastQCZip, r2FastQCZip ->
                    if ( metadata.readType == 'single' ) {
                        return [ r1FastQCZip ]
                    } else if ( metadata.readType == 'paired' ) {
                        return [ r1FastQCZip, r2FastQCZip ]
                    }
                }
            )
            .mix(
                fastqc_prealign.out.zip.flatMap { metadata, r1FastQCZip, r2FastQCZip ->
                    if ( metadata.readType == 'single' ) {
                        return [ r1FastQCZip ]
                    } else if ( metadata.readType == 'paired' ) {
                        return [ r1FastQCZip, r2FastQCZip ]
                    }
                }
            )
            .mix(trim_log)
            .mix(
                ch_sequencingDepthRaw.map { sampleMetadata, sequencingDepth -> sequencingDepth }
            )
            .mix(
                ch_sequencingDepthPrealign.map { sampleMetadata, sequencingDepth -> sequencingDepth }
            )
            .collect(
                sort: { a, b ->
                    a.name <=> b.name
                }
            )

        // run MultiQC for reads QC metrics
        multiqc_reads(
            ch_multiqcReads,
            file("${projectDir}/assets/multiqc_config.yaml"),
            "reads"
        )

    emit:
        multiqc = ch_multiqcReads
}


/**
 * Compute sample level sequencing depth from FastQC Summaries.
 *
 * Computes sequencing depth as the total count of sequenced bases in a sample divided by the total number of bases in the reference genome.
 * Sequencing depth is written to a file of tab separated values reporting the sample name and sequencing depth.
 *
 * @param fastqcSummaryOutput A tuple channel of output from FastQC Summary process with shape [metadata, fastqcSummaryReads1Json, fastqcSummaryReads2Json].
 * @param baseCountGenome A value channel of count of bases in the reference genome as a Long type.
 * @param trimStatus A string of trim status either "raw" or "prealign" to add to the output file name.
 * @return A tuple channel of sample level metadata and a tab separated value file mapping sample name to sequencing depth.
 */
def computeSequencingDepth(fastqcSummaryOutput, baseCountGenome, trimStatus) {
    def baseCountSampleLevel = fastqcSummaryOutput
        // Compute total base count across R1 and R2
        .map { metadata, fastqcSummaryReads1, fastqcSummaryReads2 -> 
            // read base counts for R1 and R2 from FastQC Summary
            def baseCountR1 = (fastqcSummaryReads1.isEmpty() ? 0 : new groovy.json.JsonSlurper().parseText(fastqcSummaryReads1.text)['base_count']) as Long
            def baseCountR2 = (fastqcSummaryReads2.isEmpty() ? 0 : new groovy.json.JsonSlurper().parseText(fastqcSummaryReads2.text)['base_count']) as Long

            // total base count is sum of R1 and R2 base count
            def baseCountTotal = baseCountR1 + baseCountR2

            return [ metadata, baseCountTotal ]
        }
        // Group total base counts at sample level
        .map { metadata, baseCountTotal -> 
            return [ metadata.sampleName, metadata, baseCountTotal ]
        }
        .groupTuple()
        // Compute sample level total base count
        .map { sampleNameKey, metadatas, baseCountTotals -> 
            // Collapse metadata at sample level
            def metadataIntersection = MetadataUtils.intersectListOfMetadata(metadatas)

            // Compute total base count in samples
            def baseCount = 0
            baseCountTotals.each { baseCountTotal ->
                baseCount += baseCountTotal
            }

            return [ metadataIntersection, baseCount ]
        }

    // Compute sequencing depth
    def sequencingDepthFile = baseCountSampleLevel
        .combine(baseCountGenome)
        .map { metadata, baseCountReads, lengthGenome ->
            def sequencingDepth = baseCountReads / lengthGenome
            return [ metadata, sequencingDepth ]
        }
        // Write sequencing depth to a file as input to MultiQC
        .collectFile() { metadata, sequencingDepth ->
            [
                "${metadata.sampleName}_${trimStatus}_seq-depth.tsv",
                "Sample Name\tDepth\n${metadata.sampleName}\t${sequencingDepth}"
            ]
        }

    // Add sample level metadata to sequencing depth file
    def sampleLevelMetadata = baseCountSampleLevel
        .map { metadata, baseCountReads ->
            return [ metadata.sampleName, metadata ]
        }
    def sequencingDepth = sequencingDepthFile
        .map { sequencingDepthFilePath -> 
            def sampleName = sequencingDepthFilePath.name.replaceFirst(/_${trimStatus}_seq-depth\.tsv$/, '')
            return [ sampleName, sequencingDepthFilePath ]
        }
        .join(sampleLevelMetadata)
        .map { sampleName, sequencingDepthFilePath, metadata ->
            return [ metadata, sequencingDepthFilePath ]
        }

    return sequencingDepth
}
