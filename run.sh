#!/bin/bash -eu

if (( $# != 4 )); then
    printf "  Usage  : %s config_file input_dir output_path log_path\n" "$0" >&2
    printf "  Example: ./run.sh /dev/null ./demo/data/ /tmp/output/ /tmp/log\n" >&2
    exit 1
fi


config=$1
input_dir=$2
output_dir=$3
log_path=$4

mkdir -p "$output_dir"

jarfile=$(readlink -m lib/BerkeleyParser-1.7.jar)
grammar=pcfgla

java -cp $jarfile edu.berkeley.nlp.PCFGLA.GrammarTrainer -path $input_dir/sample_train.txt -out $output_dir/$grammar.gr -treebank SINGLEFILE
java -cp $jarfile edu.berkeley.nlp.PCFGLA.WriteGrammar -gr $output_dir/$grammar.gr

