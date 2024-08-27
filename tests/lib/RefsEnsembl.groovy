import groovy.transform.InheritConstructors

@InheritConstructors
class RefsEnsembl extends Refs {
    String name = 'R64-1-1'
    LinkedHashMap sequences = [
        genome: [
            decomp: 'tests/data/references/R64-1-1/genome_I.fa',
            gzip:   'tests/data/references/R64-1-1/genome_I.fa.gz',
            index:  'tests/data/references/R64-1-1/genome_I.fa.fai'
        ]
    ]
    LinkedHashMap annotations = [
        gtf: [
            decomp: 'tests/data/references/R64-1-1/annotations_I.gtf',
            gzip:   'tests/data/references/R64-1-1/annotations_I.gtf.gz'
        ]
    ]
}
