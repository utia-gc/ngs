include { compute_bases_genome                          } from '../modules/compute_bases_genome.nf'
include { fastqc           as fastqc_prealign           } from '../modules/fastqc.nf'
include { fastqc           as fastqc_raw                } from '../modules/fastqc.nf'
include { multiqc          as multiqc_reads             } from '../modules/multiqc.nf'
include { sequencing_depth as sequencing_depth_prealign } from '../modules/sequencing_depth.nf'
include { sequencing_depth as sequencing_depth_raw      } from '../modules/sequencing_depth.nf'
include { Group_Reads      as Group_Reads_Raw           } from '../subworkflows/group_reads.nf'
include { Group_Reads      as Group_Reads_Prealign      } from '../subworkflows/group_reads.nf'

workflow QC_Reads {
    take:
        reads_raw
        reads_prealign
        trim_log
        genome_index

    main:
        fastqc_raw(reads_raw)
        fastqc_prealign(reads_prealign)

        compute_bases_genome(genome_index)

        Group_Reads_Raw(reads_raw)
        sequencing_depth_raw(
            Group_Reads_Raw.out.reads_grouped,
            genome_index
        )
          | collectFile() { metadata, depth ->
            [
                "${metadata.sampleName}_raw_seq-depth.tsv",
                "Sample Name\tDepth\n${metadata.sampleName}\t${depth}"
            ]
          }
          | set { ch_sequencing_depth_raw }

        Group_Reads_Prealign(reads_prealign)
        sequencing_depth_prealign(
            Group_Reads_Prealign.out.reads_grouped,
            genome_index
        )
          | collectFile() { metadata, depth ->
            [
                "${metadata.sampleName}_prealign_seq-depth.tsv",
                "Sample Name\tDepth\n${metadata.sampleName}\t${depth}"
            ]
          }
          | set { ch_sequencing_depth_prealign }

        ch_multiqc_reads = Channel.empty()
            .concat(fastqc_raw.out.zip)
            .concat(fastqc_prealign.out.zip)
            .concat(trim_log)
            .concat(ch_sequencing_depth_raw)
            .concat(ch_sequencing_depth_prealign)
            .collect()

        multiqc_reads(
            ch_multiqc_reads,
            file("${projectDir}/assets/multiqc_config.yaml"),
            "reads"
        )

    emit:
        multiqc = ch_multiqc_reads
}
