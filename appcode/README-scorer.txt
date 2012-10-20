=============================================================================
                    Coreference Resolution Scorer
=============================================================================

RUNNING THE SCORER:
   
   a. Make sure that you have python installed on your machine.
      If you're not sure if you do, use the command: whereis python

   b. Set the executable bit: chmod +x coref-scorer.py

   c. Run the program: ./coref-scorer.py <listfile> <official-keys-directory>

      For example: ./coref-scorer.py /home/riloff/listfile.txt /home/riloff/keys/

ADDITIONAL ARGUMENTS:

   -V : Verbose output, gives you more information regarding how well your 
        system performed on different types of noun phrases.  

        For example: ./coref-scorer.py /home/riloff/listfile.txt /home/riloff/keys/ -V

        CAVEAT: this option uses *heuristics* to guess which NPs are
        pronouns, common nouns, or proper nouns. So the breakdown by
        types is not guaranteed to be perfect, but hopefully this will give you 
        a general idea of how your coreference resolver is doing on each 
        type of anaphora. 

----------------------------------------------------------------------------
NOTES:

  a. The listfile should be a plain text file with a document filename
     on every line. Each filename should include an absolute path, or
     a relative path from the directory in which the scoring program is
     run. You should be able to use the same listfile that your
     coreference resolver takes as input.

  b. The official-keys-directory is a directory that contains the official answer 
     key files. 

  c. To test your setup, you can use the UNofficial answer keys as
     pretend output from a coreference resolver, and score them against the
     official answer keys. You should get 100% accuracy. The result of
     running the program should look something like this:

	Document 10 Score:  1.00
	Document 11 Score:  1.00
	Document 12 Score:  1.00
	Document 13 Score:  1.00
	Document 14 Score:  1.00
	Document 15 Score:  1.00
	Document 16 Score:  1.00
	Document 17 Score:  1.00
	Document 18 Score:  1.00
	Document 19 Score:  1.00
	Document 1 Score:  1.00
	Document 20 Score:  1.00
	Document 21 Score:  1.00
	Document 22 Score:  1.00
	Document 23 Score:  1.00
	Document 24 Score:  1.00
	Document 25 Score:  1.00
	Document 26 Score:  1.00
	Document 27 Score:  1.00
	Document 28 Score:  1.00
	Document 29 Score:  1.00
	Document 2 Score:  1.00
	Document 30 Score:  1.00
	Document 3 Score:  1.00
	Document 4 Score:  1.00
	Document 5 Score:  1.00
	Document 6 Score:  1.00
	Document 7 Score:  1.00
	Document 8 Score:  1.00
	Document 9 Score:  1.00
	-------------------------------------------------
	Final accuracy score: 1.0000
	-------------------------------------------------

