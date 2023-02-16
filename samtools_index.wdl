version 1.0

workflow samtools_index {
    input {
    	String output_directory
        #samtools parameters
        File bam_file
        #general parameters
        Int cpu = 16
        String memory = "32G"
        Int extra_disk_space = 0
        String docker = "staphb/samtools:latest"
        Int preemptible = 2
    }

    String output_directory_stripped = sub(output_directory, "/+$", "")

    call run_index {
            input:
                output_dir = output_directory_stripped,
                bam_file = bam_file,
                cpu=cpu,
                memory=memory,
                extra_disk_space=extra_disk_space,
                docker=docker,
                preemptible=preemptible
        }
    
    output {
        File bam_bai_file = run_index.bam_bai_file
    }
}

task run_index {

    input {
        String output_dir
        File bam_file
        String memory
        Int extra_disk_space
        Int cpu
        String docker
        Int preemptible
    }

    command <<<
        set -e

        mkdir -p outputs

        samtools index -@ ~{cpu} ~{bam_file} -o outputs/possorted_genome_bam.bam.bai 

        gsutil -m cp outputs/possorted_genome_bam.bam.bai ~{output_dir}/
    >>>

    output {
        File bam_bai_file = "outputs/possorted_genome_bam.bam.bai "
    }

    runtime {
        docker: docker
        memory: memory
        bootDiskSizeGb: 12
        disks: "local-disk " + ceil(size(bam_file, "GB")*2 + extra_disk_space) + " HDD"
        cpu: cpu
        preemptible: preemptible
    }

}