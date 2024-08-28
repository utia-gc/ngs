import groovy.transform.InheritConstructors

@InheritConstructors
class ReadsPELane1 extends Reads {
    LinkedHashMap metadata = [
        sampleName:   'SRR6924569',
        sampleNumber: '1',
        lane:         '001',
        readType:     'paired'
    ]
    List reads = [
        "tests/data/reads/raw/SRR6924569_S1_L001_R1_001.fastq.gz",
        "tests/data/reads/raw/SRR6924569_S1_L001_R2_001.fastq.gz"
    ]
    LinkedHashMap trimLogs = [
        cutadapt: 'tests/reads/trimmed/cutadapt/SRR6924569_L001_cutadapt-log.txt',
        fastp:    'tests/reads/trimmed/fastp/SRR6924569_L001_fastp.json',
    ]
}
