import groovy.transform.InheritConstructors

@InheritConstructors
class ReadsPELane2 extends Reads {
    LinkedHashMap metadata = [
        sampleName:   'SRR6924569',
        sampleNumber: '1',
        lane:         '002',
        readType:     'paired'
    ]
    List reads = [
        "tests/data/reads/raw/SRR6924569_S1_L002_R1_001.fastq.gz",
        "tests/data/reads/raw/SRR6924569_S1_L002_R2_001.fastq.gz"
    ]
    LinkedHashMap trimLogs = [
        cutadapt: 'tests/data/reads/trimmed/cutadapt/SRR6924569_L002_cutadapt-log.txt',
        fastp:    'tests/data/reads/trimmed/fastp/SRR6924569_L002_fastp.json',
    ]
}
