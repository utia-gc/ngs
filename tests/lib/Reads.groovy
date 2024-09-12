abstract class Reads {
    public getSampleName() {
        this.metadata.sampleName
    }

    public getReplicate() {
        this.metadata.replicate
    }

    public getTarget() {
        this.metadata.target
    }

    public getMode() {
        this.metadata.mode
    }

    public getControlType() {
        this.metadata.controlType
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
        // if the sample metadata contains all the chip information, build the root of the stem name with it
        def stemNameRoot = (this.mode && this.target && this.replicate)
            ? "${this.getSampleName()}_${(this.getMode() == 'control') ? this.getControlType() : this.getMode()}_${this.getTarget()}_rep${this.getReplicate()}"
            : this.getSampleName()

        // if the sample metadata contains the lane info, add it to the root of the stem name
        def stemName = (this.lane)
            ? "${stemNameRoot}_L${this.getLane()}"
            : stemNameRoot

        return stemName
    }


    /**
     * Get the stem name of a fastq file without the lane information.
     * 
     * Get the stem name of a fastq file. 
     * For fastq files that follow Illumina naming conventions this should be the same as '<SampleName>'.
     * @see https://support.illumina.com/help/BaseSpace_OLH_009008/Content/Source/Informatics/BS/NamingConvention_FASTQ-files-swBS.htm
     *
     * @return String fastq stem name.
     */
    public getStemNameWithoutLane() {
        // if the sample metadata contains all the chip information, build the root of the stem name with it
        def stemName = (this.mode && this.target && this.replicate)
            ? "${this.getSampleName()}_${(this.getMode() == 'control') ? this.getControlType() : this.getMode()}_${this.getTarget()}_rep${this.getReplicate()}"
            : this.getSampleName()

        return stemName
    }


    /**
     * Get the stem name for peak calls.
     * 
     * Get the stem name of a fastq file. 
     * For fastq files that follow Illumina naming conventions this should be the same as '<SampleName>'.
     * @see https://support.illumina.com/help/BaseSpace_OLH_009008/Content/Source/Informatics/BS/NamingConvention_FASTQ-files-swBS.htm
     *
     * @return String fastq stem name.
     */
    public getStemNamePeakCalls() {
        // the stem name must start with the sample name
        ArrayList stemNameComponents = [metadata.sampleName]
        // add target info and control if applicable
        stemNameComponents += (metadata.controlType == "none") ? metadata.target : "${metadata.target}-vs-${metadata.controlType}"
        // add replicate info
        if (metadata.replicate) stemNameComponents += "rep${metadata.replicate}"

        return stemNameComponents.join('_')
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
