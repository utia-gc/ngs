abstract class Reads {
    public getSampleName() {
        this.metadata.sampleName
    }
    
    public getSampleNumber() {
        this.metadata.sampleNumber
    }
    
    public getLane() {
        this.metadata.lane
    }
    
    public getReadType() {
        this.metadata.readType
    }
    
    public getR1() {
        this.reads[0]
    }
    
    public getR2() {
        this.reads[1]
    }

    /**
     * Get the stem name of a fastq file.
     * 
     * Get the stem name of a fastq file. 
     * For fastq files that follow Illumina naming conventions this should be the same as '<SampleName>_L<LaneNumber>'.
     * @see https://support.illumina.com/help/BaseSpace_OLH_009008/Content/Source/Informatics/BS/NamingConvention_FASTQ-files-swBS.htm
     *
     * @return String fastq stem name.
     */
    public getStemName() {
        "${this.getSampleName()}_L${this.getLane()}"
    }

    public getRGFields() {
        [
            'ID': "${this.getSampleName()}.${this.getLane()}",
            'SM': "${this.getSampleName()}",
            'LB': "${this.getSampleName()}",
            'PL': 'ILLUMINA'
        ]
    }

    public getRGLine() {
        def rgFields = this.getRGFields()


        "@RG\tID:${rgFields.get('ID')}\tSM:${rgFields.get('SM')}\tLB:${rgFields.get('LB')}\tPL:${rgFields.get('PL')}"
    }

    public getR1SimpleName() {
        // regexp pattern that matches common fastq filename endings
        // matches: fastq.gz, fq.gz, fastq, fq
        def fastqSuffix = ~/\.f(?:ast)?q(?:\.gz)?$/

        file(this.getR1()).getName() - fastqSuffix
    }

    public getR2SimpleName() {
        // regexp pattern that matches common fastq filename endings
        // matches: fastq.gz, fq.gz, fastq, fq
        def fastqSuffix = ~/\.f(?:ast)?q(?:\.gz)?$/

        file(this.getR2()).getName() - fastqSuffix
    }

    public getTrimLogCutadapt() {
        this.trimLogs.cutadapt
    }

    public getTrimLogFastp() {
        this.trimLogs.fastp
    }
}
