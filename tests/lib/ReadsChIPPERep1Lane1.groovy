import groovy.transform.InheritConstructors

@InheritConstructors
class ReadsChIPPERep1Lane1 extends Reads {
    LinkedHashMap metadata = [
        sampleName:   'wt_ip1',
        lane:         '001',
        replicate:    '1',
        target:       'FLAG-IP1',
        readType:     'paired',
        mode:         'chip',
        controlType:  'input',
    ]
    List reads = [
        "tests/data/reads/raw/wt_antiflag_ip1_rep1_S1_L001_R1_001.fastq.gz",
        "tests/data/reads/raw/wt_antiflag_ip1_rep1_S1_L001_R2_001.fastq.gz"
    ]
    String bam      = "tests/data/mappings/wt_antiflag_ip1_rep1.bam"
    String bamIndex = "tests/data/mappings/wt_antiflag_ip1_rep1.bam.bai"
}
