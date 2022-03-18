version 1.0

workflow mhcquant {
	input{
		File samplesheet
		String outdir = "./results"
		String? email
		String? multiqc_title
		File? fasta
		Boolean? include_proteins_from_vcf
		Boolean? skip_decoy_generation
		Int pick_ms_levels = 2
		Boolean? run_centroidisation
		Int peptide_min_length = 8
		Int peptide_max_length = 12
		Float fragment_mass_tolerance = 0.02
		Int precursor_mass_tolerance = 5
		Int? fragment_bin_offset
		Int number_mods = 3
		Int num_hits = 1
		String digest_mass_range = "800:2500"
		String prec_charge = "2:3"
		String activation_method = "ALL"
		String enzyme = "unspecific cleavage"
		Int max_rt_alignment_shift = 300
		String? fixed_mods
		String variable_mods = "Oxidation (M)"
		Boolean? use_x_ions
		Boolean? use_z_ions
		Boolean? use_a_ions
		Boolean? use_c_ions
		Boolean? use_NL_ions
		Boolean? remove_precursor_peak
		Int spectrum_batch_size = 500
		String? vcf_sheet
		String fdr_level = "peptide_level_fdrs"
		Float fdr_threshold = 0.01
		Boolean? refine_fdr_on_predicted_subset
		Int subset_affinity_threshold = 500
		Int? description_correct_features
		Boolean? klammer
		Int? subset_max_train
		Boolean? skip_quantification
		String? quantification_fdr
		Float? quantification_min_prob
		String? allele_sheet
		Boolean? predict_class_1
		Boolean? predict_class_2
		String variant_reference = "GRCH38"
		String variant_annotation_style = "SNPEFF"
		Boolean? variant_indel_filter
		Boolean? variant_frameshift_filter
		Boolean? variant_snp_filter
		Boolean? predict_RT
		String custom_config_version = "master"
		Boolean? skip_multiqc
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			samplesheet = samplesheet,
			outdir = outdir,
			email = email,
			multiqc_title = multiqc_title,
			fasta = fasta,
			include_proteins_from_vcf = include_proteins_from_vcf,
			skip_decoy_generation = skip_decoy_generation,
			pick_ms_levels = pick_ms_levels,
			run_centroidisation = run_centroidisation,
			peptide_min_length = peptide_min_length,
			peptide_max_length = peptide_max_length,
			fragment_mass_tolerance = fragment_mass_tolerance,
			precursor_mass_tolerance = precursor_mass_tolerance,
			fragment_bin_offset = fragment_bin_offset,
			number_mods = number_mods,
			num_hits = num_hits,
			digest_mass_range = digest_mass_range,
			prec_charge = prec_charge,
			activation_method = activation_method,
			enzyme = enzyme,
			max_rt_alignment_shift = max_rt_alignment_shift,
			fixed_mods = fixed_mods,
			variable_mods = variable_mods,
			use_x_ions = use_x_ions,
			use_z_ions = use_z_ions,
			use_a_ions = use_a_ions,
			use_c_ions = use_c_ions,
			use_NL_ions = use_NL_ions,
			remove_precursor_peak = remove_precursor_peak,
			spectrum_batch_size = spectrum_batch_size,
			vcf_sheet = vcf_sheet,
			fdr_level = fdr_level,
			fdr_threshold = fdr_threshold,
			refine_fdr_on_predicted_subset = refine_fdr_on_predicted_subset,
			subset_affinity_threshold = subset_affinity_threshold,
			description_correct_features = description_correct_features,
			klammer = klammer,
			subset_max_train = subset_max_train,
			skip_quantification = skip_quantification,
			quantification_fdr = quantification_fdr,
			quantification_min_prob = quantification_min_prob,
			allele_sheet = allele_sheet,
			predict_class_1 = predict_class_1,
			predict_class_2 = predict_class_2,
			variant_reference = variant_reference,
			variant_annotation_style = variant_annotation_style,
			variant_indel_filter = variant_indel_filter,
			variant_frameshift_filter = variant_frameshift_filter,
			variant_snp_filter = variant_snp_filter,
			predict_RT = predict_RT,
			custom_config_version = custom_config_version,
			skip_multiqc = skip_multiqc,
			custom_config_base = custom_config_base,
			config_profile_name = config_profile_name,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			help = help,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			max_multiqc_email_size = max_multiqc_email_size,
			monochrome_logs = monochrome_logs,
			multiqc_config = multiqc_config,
			tracedir = tracedir,
			validate_params = validate_params,
			show_hidden_params = show_hidden_params,
			enable_conda = enable_conda,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-mhcquant/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		File samplesheet
		String outdir = "./results"
		String? email
		String? multiqc_title
		File? fasta
		Boolean? include_proteins_from_vcf
		Boolean? skip_decoy_generation
		Int pick_ms_levels = 2
		Boolean? run_centroidisation
		Int peptide_min_length = 8
		Int peptide_max_length = 12
		Float fragment_mass_tolerance = 0.02
		Int precursor_mass_tolerance = 5
		Int? fragment_bin_offset
		Int number_mods = 3
		Int num_hits = 1
		String digest_mass_range = "800:2500"
		String prec_charge = "2:3"
		String activation_method = "ALL"
		String enzyme = "unspecific cleavage"
		Int max_rt_alignment_shift = 300
		String? fixed_mods
		String variable_mods = "Oxidation (M)"
		Boolean? use_x_ions
		Boolean? use_z_ions
		Boolean? use_a_ions
		Boolean? use_c_ions
		Boolean? use_NL_ions
		Boolean? remove_precursor_peak
		Int spectrum_batch_size = 500
		String? vcf_sheet
		String fdr_level = "peptide_level_fdrs"
		Float fdr_threshold = 0.01
		Boolean? refine_fdr_on_predicted_subset
		Int subset_affinity_threshold = 500
		Int? description_correct_features
		Boolean? klammer
		Int? subset_max_train
		Boolean? skip_quantification
		String? quantification_fdr
		Float? quantification_min_prob
		String? allele_sheet
		Boolean? predict_class_1
		Boolean? predict_class_2
		String variant_reference = "GRCH38"
		String variant_annotation_style = "SNPEFF"
		Boolean? variant_indel_filter
		Boolean? variant_frameshift_filter
		Boolean? variant_snp_filter
		Boolean? predict_RT
		String custom_config_version = "master"
		Boolean? skip_multiqc
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /mhcquant-2.2.0  -profile truwl,nfcore-mhcquant  --input ~{samplesheet} 	~{"--samplesheet '" + samplesheet + "'"}	~{"--outdir '" + outdir + "'"}	~{"--email '" + email + "'"}	~{"--multiqc_title '" + multiqc_title + "'"}	~{"--fasta '" + fasta + "'"}	~{true="--include_proteins_from_vcf  " false="" include_proteins_from_vcf}	~{true="--skip_decoy_generation  " false="" skip_decoy_generation}	~{"--pick_ms_levels " + pick_ms_levels}	~{true="--run_centroidisation  " false="" run_centroidisation}	~{"--peptide_min_length " + peptide_min_length}	~{"--peptide_max_length " + peptide_max_length}	~{"--fragment_mass_tolerance " + fragment_mass_tolerance}	~{"--precursor_mass_tolerance " + precursor_mass_tolerance}	~{"--fragment_bin_offset " + fragment_bin_offset}	~{"--number_mods " + number_mods}	~{"--num_hits " + num_hits}	~{"--digest_mass_range '" + digest_mass_range + "'"}	~{"--prec_charge '" + prec_charge + "'"}	~{"--activation_method '" + activation_method + "'"}	~{"--enzyme '" + enzyme + "'"}	~{"--max_rt_alignment_shift " + max_rt_alignment_shift}	~{"--fixed_mods '" + fixed_mods + "'"}	~{"--variable_mods '" + variable_mods + "'"}	~{true="--use_x_ions  " false="" use_x_ions}	~{true="--use_z_ions  " false="" use_z_ions}	~{true="--use_a_ions  " false="" use_a_ions}	~{true="--use_c_ions  " false="" use_c_ions}	~{true="--use_NL_ions  " false="" use_NL_ions}	~{true="--remove_precursor_peak  " false="" remove_precursor_peak}	~{"--spectrum_batch_size " + spectrum_batch_size}	~{"--vcf_sheet '" + vcf_sheet + "'"}	~{"--fdr_level '" + fdr_level + "'"}	~{"--fdr_threshold " + fdr_threshold}	~{true="--refine_fdr_on_predicted_subset  " false="" refine_fdr_on_predicted_subset}	~{"--subset_affinity_threshold " + subset_affinity_threshold}	~{"--description_correct_features " + description_correct_features}	~{true="--klammer  " false="" klammer}	~{"--subset_max_train " + subset_max_train}	~{true="--skip_quantification  " false="" skip_quantification}	~{"--quantification_fdr '" + quantification_fdr + "'"}	~{"--quantification_min_prob " + quantification_min_prob}	~{"--allele_sheet '" + allele_sheet + "'"}	~{true="--predict_class_1  " false="" predict_class_1}	~{true="--predict_class_2  " false="" predict_class_2}	~{"--variant_reference '" + variant_reference + "'"}	~{"--variant_annotation_style '" + variant_annotation_style + "'"}	~{true="--variant_indel_filter  " false="" variant_indel_filter}	~{true="--variant_frameshift_filter  " false="" variant_frameshift_filter}	~{true="--variant_snp_filter  " false="" variant_snp_filter}	~{true="--predict_RT  " false="" predict_RT}	~{"--custom_config_version '" + custom_config_version + "'"}	~{true="--skip_multiqc  " false="" skip_multiqc}	~{"--custom_config_base '" + custom_config_base + "'"}	~{"--config_profile_name '" + config_profile_name + "'"}	~{"--config_profile_description '" + config_profile_description + "'"}	~{"--config_profile_contact '" + config_profile_contact + "'"}	~{"--config_profile_url '" + config_profile_url + "'"}	~{"--max_cpus " + max_cpus}	~{"--max_memory '" + max_memory + "'"}	~{"--max_time '" + max_time + "'"}	~{true="--help  " false="" help}	~{"--email_on_fail '" + email_on_fail + "'"}	~{true="--plaintext_email  " false="" plaintext_email}	~{"--max_multiqc_email_size '" + max_multiqc_email_size + "'"}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--multiqc_config '" + multiqc_config + "'"}	~{"--tracedir '" + tracedir + "'"}	~{true="--validate_params  " false="" validate_params}	~{true="--show_hidden_params  " false="" show_hidden_params}	~{true="--enable_conda  " false="" enable_conda}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-mhcquant:2.2.0_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    