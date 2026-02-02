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
        ch_basesGenome = compute_bases_genome.out.bases
            .map { bases -> return Long.valueOf(bases) }

        /*
            Compute read depth of raw reads
        */
        // Count bases in raw reads at sequence result level
        fastqc_summary_raw(fastqc_raw.out.zip)
        // Compute sequencing depth for raw reads at sample level
        // Sequencing depth = Count bases in reads for a sample / count bases in the reference genome
        // Count bases in reads for sample = Sum of base count each sequence result belonging to sample
        ch_sequencingDepthRaw = fastqc_summary_raw.out.fastqcSummary
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
            .combine(ch_basesGenome)
            .map { metadata, basesInReads, basesInGenome ->
                def sequencingDepth = basesInReads / basesInGenome
                return [ metadata, sequencingDepth ]
            }
            // Write sequencing depth to a file as input to MultiQC
            .collectFile() { metadata, sequencingDepth ->
                [
                    "${metadata.sampleName}_raw_seq-depth.tsv",
                    "Sample Name\tDepth\n${metadata.sampleName}\t${sequencingDepth}"
                ]
            }

        /*
            Compute read depth of prealign reads
        */
        // Count bases in prealign reads at sequence result level
        fastqc_summary_prealign(fastqc_prealign.out.zip)
        // Compute sequencing depth for prealign reads at sample level
        // Sequencing depth = Count bases in reads for a sample / count bases in the reference genome
        // Count bases in reads for sample = Sum of base count each sequence result belonging to sample
        ch_sequencingDepthPrealign = fastqc_summary_prealign.out.fastqcSummary
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
            .combine(ch_basesGenome)
            .map { metadata, basesInReads, basesInGenome ->
                def sequencingDepth = basesInReads / basesInGenome
                return [ metadata, sequencingDepth ]
            }
            // Write sequencing depth to a file as input to MultiQC
            .collectFile() { metadata, sequencingDepth ->
                [
                    "${metadata.sampleName}_prealign_seq-depth.tsv",
                    "Sample Name\tDepth\n${metadata.sampleName}\t${sequencingDepth}"
                ]
            }

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
            .mix(ch_sequencingDepthRaw)
            .mix(ch_sequencingDepthPrealign)
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
