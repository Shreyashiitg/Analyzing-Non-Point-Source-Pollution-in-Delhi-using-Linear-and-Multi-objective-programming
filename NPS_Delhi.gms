Sets
    i Land-use types / AL, FL, GL, WR, CL /;  

Parameters
    ECn(i) Export Coefficients for TN(t per km²·yr) / AL 2.90, FL 0.30, GL 1.00, WR 1.50, CL 1.10 /  
    ECp(i) Export Coefficients for TP(t per km²·yr) / AL 0.90, FL 0.15, GL 0.17, WR 0.04, CL 0.50 /  
    BT(i)  Economic Benefits (10^6 yuan perkm²) / AL 6.77, FL 2.64, GL 0.12, WR 5.19, CL 62.76 /  
    LB(i)  Lower Bounds (km²)  / AL 400, FL 1353, GL 0, WR 96.16, CL 800 /  
    UB(i)  Upper Bounds (km²)  / AL 505.28, FL 5093.44, GL 10, WR 120, CL 1000 /; 
Scalar
    TA  Total area (km²)/6765/  
    SDN TN reduction(t per yr) /4142.28/  
    SDP TP reduction(t per yr) /1679.3/
    alpha /100000/;

Variables
    X(i)   "Area of each land-use type (km²)"
    Z      "Total economic benefit (yuan)";

Positive Variables X;
Positive Variable SlackLB(i), SlackUB(i);

Equations
    Obj    "Objective function"
    TN_Cons "TN constraint"
    TP_Cons "TP constraint"
    Area_Cons "Total area constraint"
    BoundsSlack1(i) "Lower bounds for land use types"
    BoundsSlack2(i) "Upper bounds for land use types";

Obj ..        Z =e= sum(i, BT(i) * X(i))-alpha*(sum(i,SlackLB(i)+SlackUB(i)));
TN_Cons ..    sum(i, ECn(i) * X(i)) =l= SDN;
TP_Cons ..    sum(i, ECp(i) * X(i)) =l= SDP;
Area_Cons ..  sum(i, X(i)) =l= TA;
BoundsSlack1(i) .. (LB(i) - SlackLB(i)) =l= X(i);
BoundsSlack2(i).. X(i) =l=( UB(i) + SlackUB(i));

Model LandUseOptimization /all/;
Solve LandUseOptimization using LP maximizing Z;

Display X.l, Z.l;
