#! /bin/bash
echo -e "Running the first devset\n\n"
echo -e "======================================\n"
./jbin/jruby main.rb ./devset/outputList.txt ./results

echo -e "======================================"
echo -e "running the grader..."
echo -e "======================================"
./test/coref-scorer.py listfile.txt ./devset/officialkeys >> devset1_grade.txt


echo -e "Running the coref resolver on testset1\n\n"
echo -e "======================================"
./jbin/jruby main.rb ./testset1/testset1.txt ./results


echo -e "======================================"
echo -e "running the grader..."
echo -e "======================================"
./test/coref-scorer.py listfile.txt ./testset1/officialkeys >> testset1_grade.txt
