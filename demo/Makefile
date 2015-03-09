evalb=../EVALB/evalb
evalb_param=../EVALB/sample/sample.prm
jarfile=../lib/BerkeleyParser-1.7.jar
grammar=eng_MLE

.SECONDARY: wsj_test.22.txt wsj_gold.22.txt wsj_pred.22.txt $(grammar).read.gr $(grammar).gr

all:
	@cat README
clean:
	rm -f wsj_pred.22.txt $(grammar).read.gr

wsj_test.22.txt:
	@echo "You need to download wsj_test.22.txt"
	@exit 1

wsj_gold_22.txt:
	@echo "You need to download wsj_gold.22.txt"
	@exit 1

$(grammar).gr:
	@echo "You need to download $(grammar).gr"
	@exit 1

evalb:
	@if [ ! -e $(evalb) ]; then echo "$(evalb) does not exist. You need to download EVALB."; fi
	@exit 1

$(grammar).gr.grammar: $(grammar).gr
	java -cp $(jarfile) edu.berkeley.nlp.PCFGLA.WriteGrammar -gr $(grammar).gr

$(grammar).read.gr: $(grammar).gr.grammar
	java -cp $(jarfile) edu.berkeley.nlp.PCFGLA.ReadGrammar -gr $(grammar).gr.grammar -lex $(grammar).gr.lexicon -st $(grammar).gr.states -out $(grammar).read.gr

wsj_pred.22.txt: $(grammar).read.gr wsj_test.22.txt
	java -jar $(jarfile) -noHierarchy -gr $(grammar).read.gr -inputFile wsj_test.22.txt -nThreads 4 -outputFile wsj_pred.22.txt

test: evalb wsj_pred.22.txt wsj_gold.22.txt
	$(evalb) -p $(evalb_param) wsj_gold.22.txt wsj_pred.22.txt

.PHONY: all clean
