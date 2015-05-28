SHELL=/bin/bash
evalb=../EVALB/evalb
evalb_param=../EVALB/new.prm
jarfile=../lib/BerkeleyParser-ppaml-1.8.jar
grammar=eng_MLE

.SECONDARY: data/sample_test.txt data/sample_gold.txt data/sample_pred.txt $(grammar).read.gr $(grammar).gr

all:
	@cat README
clean:
	rm -f data/sample_pred.txt $(grammar).read.gr

data/sample_test.txt:
	@echo "You need to download data/sample_test.txt"
	@exit 1

data/sample_gold.txt:
	@echo "You need to download data/sample_gold.txt"
	@exit 1

$(grammar).gr:
	@echo "You need to download $(grammar).gr"
	@exit 1

evalb:
	@output=$$($(evalb) 2>&1); \
	normal="Can't open gold file ((null))"; \
	if [[ $$output != $$normal ]]; then cd ../EVALB; make clean; make; cd ../demo; if [ $$? -ne 0 ]; then echo "Please compile evalb manually."; exit 1; fi; fi

$(grammar).gr.grammar: $(grammar).gr
	java -cp $(jarfile) edu.berkeley.nlp.PCFGLA.WriteGrammar -gr $(grammar).gr

$(grammar).read.gr: $(grammar).gr.grammar
	java -cp $(jarfile) edu.berkeley.nlp.PCFGLA.ReadGrammar -gr $(grammar).gr.grammar -lex $(grammar).gr.lexicon -st $(grammar).gr.states -out $(grammar).read.gr

data/sample_pred.txt: $(grammar).read.gr data/sample_test.txt
	java -jar $(jarfile) -noHierarchy -gr $(grammar).read.gr -inputFile data/sample_test.txt -nThreads 1 -outputFile data/sample_pred.txt

test: evalb data/sample_pred.txt data/sample_gold.txt
	$(evalb) -p $(evalb_param) data/sample_gold.txt data/sample_pred.txt

.PHONY: all clean
