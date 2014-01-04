#! /bin/bash
echo -e "Running the first devset\n\n"
echo -e "======================================\n"
./jrubyLib/jbin/jruby ./source/main.rb $1 $2

#echo -e "======================================"
#echo -e "running the grader..."
#echo -e "======================================"
#./test/coref-scorer.py listfile.txt ./devset/officialkeys >> devset1_grade.txt