import groovy.transform.InheritConstructors

@InheritConstructors
class ReadsInputPERep2Lane1 extends Reads {
    LinkedHashMap metadata = [
        sampleName:   'wt_ip1',
        lane:         '001',
        replicate:    '2',
        target:       'FLAG-IP1',
        readType:     'paired',
        mode:         'control', 
        controlType:  'input',
    ]
    List reads = [
        "tests/data/reads/raw/wt_input_ip1_rep2_S1_L001_R1_001.fastq.gz",
        "tests/data/reads/raw/wt_input_ip1_rep2_S1_L001_R2_001.fastq.gz"
    ]
    String bam      = "tests/data/mappings/wt_input_ip1_rep2.bam"
    String bamIndex = "tests/data/mappings/wt_input_ip1_rep2.bam.bai"
}
