#!/bin/bash -eu

if (( $# != 4 )); then
    printf "Usage: %s config_file input_dir output_path log_path\n" "$0" >&2
    exit 1
fi

config=$1
input_dir=$2
output_dir=$3
log_path=$4

mkdir -p "$output_dir"

jarfile=$(readlink -m lib/BerkeleyParser-1.7.jar)
grammar=pcfgla

# in reality we would not have a .gr file, but instead
#   would be reading out of
#     '$input_dir/sample_train.txt'
#   to produce the files
#     '$output/pcfgla.grammar'
#     '$output/pcfgla.lexicon'
#     '$output/pcfgla.states'
#   to address this concern we are re-assigning 
#   'input_dir' to fit this example executable
#   TA2-4 teams should not be using '.gr' files.
#   in their submitted solution
input_dir=$(readlink -m demo)
java -cp $jarfile edu.berkeley.nlp.PCFGLA.WriteGrammar -gr $input_dir/eng_MLE.gr

for i in $input_dir/*.{lexicon,grammar,states}; do
  fname=$(basename $i)
  mv $i $output_dir/$grammar.${fname##*.} # preserves the suffix
done
rm -f $output_dir/*.gr

