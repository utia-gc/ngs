/**
 * Process to compute average sequencing depth.
 *
 * Compute average sequencing depth of fastq files for a reference genome.
 * 
 * @input reads the reads channel of format [metadata, [R1, R2]] where R2 is optional.
 * @input fai the fasta index of the reference genome.
 * @emit depth path to file of average sequencing depth.
 */
process sequencing_depth {
    tag "${metadata.sampleName}"

    label 'biopython'

    label 'def_cpu'
    label 'lil_mem'
    label 'med_time'

    input:
        tuple val(metadata), path(reads1), path(reads2)
        path fai

    output:
        tuple val(metadata), stdout, emit: depth

    script:
        String stemName = MetadataUtils.buildStemName(metadata)
        def reads = (metadata.readType == 'single') ? "${reads1}" : "${reads1} ${reads2}"

        """
        #!/usr/bin/env python

        import csv
        import gzip

        from Bio import SeqIO

        def main() -> None:
            bases_in_reads = count_bases_in_fastqs('${reads}'.split())
            bases_in_reference = compute_bases_in_fai('${fai}')

            print(bases_in_reads / bases_in_reference, end='')   


        def count_bases_in_fastqs(fastqs: list[str]) -> int:
            bases_in_fastqs = 0
            for fastq in fastqs:
                bases_in_fastqs += count_bases_in_fastq(fastq)

            return bases_in_fastqs


        def count_bases_in_fastq(fastq: str) -> int:
            with gzip.open(fastq, "rt") as in_fh:
                bases_in_fastq = 0
                for record in SeqIO.parse(in_fh, "fastq"):
                    bases_in_fastq += len(record.seq)

                return bases_in_fastq


        def compute_bases_in_fai(fai: str) -> int:
            fai_column_names = ("NAME", "LENGTH", "OFFSET", "LINEBASES", "LINEWIDTH")
            with open(fai, 'r') as in_fh:
                fai_reader = csv.DictReader(in_fh, delimiter='\t', fieldnames=fai_column_names)
                
                bases_in_fai = 0
                for row in fai_reader:
                    bases_in_fai += int(row.get('LENGTH'))
                
                return bases_in_fai


        if __name__ == "__main__":
            main()
        """
}
