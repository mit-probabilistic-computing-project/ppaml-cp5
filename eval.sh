#!/bin/bash -eu


if (( $# != 3 )); then
    printf "Usage: %s solution_output eval_data resultant_path \n" "$0" >&2
    exit 1
fi
mkdir -p "$3"

solution=$1
data=$2
result=$3

set -x

# test files
test_file=$(ls $data/*test.txt | head -n 1)
gold_file=$(ls $data/*gold.txt | head -n 1)

if ! [[ -e ${test_file} ]]; then
   echo "${test_file} does not exist"
   exit 1 
fi
if ! [[ -e ${gold_file} ]]; then
   echo "${gold_file} does not exist"
   exit 1 
fi

# output files
parsed_file=$result/parsed.txt
eval_file=$result/eval.txt
f1_file=$result/f1.txt

# input files
grammar=pcfgla
rules=$solution/$grammar.grammar
lexicon=$solution/$grammar.lexicon
states=$solution/$grammar.states

if ! [[ -e $rules ]]; then
   echo "$rules does not exist"
   exit 1 
fi
if ! [[ -e $lexicon ]]; then
   echo "$lexicon does not exist"
   exit 1 
fi
if ! [[ -e $states ]]; then
   echo "$states does not exist"
   exit 1
fi

evalb=EVALB/evalb 
evalb_param=EVALB/new.prm

jarfile=lib/BerkeleyParser-ppaml-1.8.jar

# read and dump grammar object
echo "Reading grammar ..."
java -cp $jarfile edu.berkeley.nlp.PCFGLA.ReadGrammar -gr $rules -lex $lexicon -st $states -out $grammar.gr
rc=$?
echo "reading grammar exited with return code $rc"
if [ $rc -ne 0 ]; then exit $rc; fi

# parse
echo "Parsing ..."
java -jar $jarfile -noHierarchy -gr $grammar.gr -inputFile ${test_file} -nThreads 1 -outputFile ${parsed_file}
rc=$?
echo "parsing exited with return code $rc"
if [ $rc -ne 0 ]; then exit $rc; fi


# evaluation
echo "Evaluating ..."
$evalb -p ${evalb_param} ${gold_file} ${parsed_file} > ${eval_file} 
rc=$?
echo "evaluatiing exited with return code $rc"
if [ $rc -ne 0 ]; then exit $rc; fi

tail -n 6 ${eval_file} | head -n 1 | awk '{print $4}' > ${f1_file}
echo 'F1 Measure: ' $(cat ${f1_file}) 
