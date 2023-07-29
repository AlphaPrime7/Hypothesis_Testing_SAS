/*first SAS macro*/
%macro prnt(var,sum);
proc print data=project.weight;
  sum &sum;
  run;
%mend prnt;

%prnt(Student_Weight, Student_Weight)
