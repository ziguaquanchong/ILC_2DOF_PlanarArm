close all;
clear global;
%% _COSTRUZIONE ROBOT - DENAVIT-HARTEMBERG_ %%
%% creazione di un corpo rigido
robot = robotics.RigidBodyTree();
%costruzione della tabella con il seguente ordine
%(a, alpha, d, theta) graficamente alcune giunzioni
%sono 'nascoste' poich� fanno parte del polso

%raggiungo il punto p=(x,y,z) con orientazione iniziale
x=(1+rand-0.5)*rand-0.5;
y=(1+rand-0.5)*rand-0.5;
z=0.7+rand;

T=[1 0 0 x;
    0 1 0 y;
    0 0 1 z;
    0 0 0 1];
q=ik06(T);
dhparams = [0     pi/2   0.5    q(1);
    1      0      0     q(2);
    1     pi/2	  0     q(3);
    0    -pi/2	  0     q(4);
    0     pi/2	  0     q(5);
    0      0     0.2    q(6)];
%creazione e aggiunta degli arti revoluti
body1 = robotics.RigidBody('body1');
jnt1 = robotics.Joint('jnt1','revolute');
body2 = robotics.RigidBody('body2');
jnt2 = robotics.Joint('jnt2','revolute');
body3 = robotics.RigidBody('body3');
jnt3 = robotics.Joint('jnt3','revolute');
body4 = robotics.RigidBody('body4');
jnt4 = robotics.Joint('jnt4','revolute');
body5 = robotics.RigidBody('body5');
jnt5 = robotics.Joint('jnt5','revolute');
body6 = robotics.RigidBody('body6');
jnt6 = robotics.Joint('jnt6','revolute');
%% creo matrici per ciascun DOF richiamando DHmatrix
%funzione per convertire i parametri DH in matrice
A01=DHmatrix(dhparams(1,:));
A12=DHmatrix(dhparams(2,:));
A23=DHmatrix(dhparams(3,:));
A34=DHmatrix(dhparams(4,:));
A45=DHmatrix(dhparams(5,:));
A56=DHmatrix(dhparams(6,:));
%impostazione degli arti secondo le matrici precedenti
setFixedTransform(jnt1,A01);
setFixedTransform(jnt2,A12);
setFixedTransform(jnt3,A23);
setFixedTransform(jnt4,A34);
setFixedTransform(jnt5,A45);
setFixedTransform(jnt6,A56);
%assegnazione degli arti
body1.Joint = jnt1;
body2.Joint = jnt2;
body3.Joint = jnt3;
body4.Joint = jnt4;
body5.Joint = jnt5;
body6.Joint = jnt6;
%creazione dell'albero genealogico
addBody(robot,body1,'base');
addBody(robot,body2,'body1');
addBody(robot,body3,'body2');
addBody(robot,body4,'body3');
addBody(robot,body5,'body4');
addBody(robot,body6,'body5');
%mostra albero genealogico
showdetails(robot);
%% cinematica diretta
%matrice anthropomorphic arm MODIFICATA
%(differisce dalla deifinizione per la matrice A23)
T03=A01*A12*A23;
%matrice spherical wrist MODIFICATA
%(differisce dalla deifinizione per la matrice A34)
T36=A34*A45*A56;
T06= T03*T36; %matrice diretta robot 4x4
%% parametri endEffector
%a 'APPROCCIO'
%s 'SLITTAMENTO'
%n 'NORMA'
%p 'PUNTO'
%braccio
n03=T03(1:3,1);
s03=T03(1:3,2);
a03=T03(1:3,3);
p03=T03(1:3,4);
%polso
n36=T36(1:3,1);
s36=T36(1:3,2);
a36=T36(1:3,3);
p36=T36(1:3,4);
%intera stuttura
n06=T06(1:3,1);
s06=T06(1:3,2);
a06=T06(1:3,3);
p06=T06(1:3,4);
%matrici di rotazione
R03=[n03 s03 a03];
R06=[n06 s06 a06];
R36=[n36 s36 a36];
%pe posizione dell'endEffector
pe_x=p06(1);
pe_y=p06(2);
pe_z=p06(3);
%pw posizione del Frame3 finale del braccio antropomorfo
%(sottraggo lunghezza polso e altezza primo frame)
pw_x=pe_x+(dhparams(6,3)+dhparams(4,3))*a06(1);
pw_y=pe_y+(dhparams(6,3)+dhparams(4,3))*a06(2);
pw_z=pe_z+(dhparams(6,3)+dhparams(4,3))*a06(3)-dhparams(1,3);

%% cinematica inversa braccio
p=[x;y;z];
display(p);
deg06=rad2deg(q);
display(deg06);
%mostra robot con tutti teta a 0
figure(1)
show(robot);
title('MANIPOLATORE ANTROPOMORFO CON POLSO SFERICO (6DOF)');
axis auto;
camva('auto');
hold on;
h=scatter3(T(1,4),T(2,4),T(3,4),'o');
h.SizeData=100;
hold off;
% %% spazio di lavoro del manipolatore
% q1=0:0.5:2*pi;
% q2=0:0.5:pi/2;
% q3=0:0.5:pi/2;
% q4=0:0.5:2*pi;
% q5=0:0.5:2*pi;
% q6=0:0.5:pi/2;
% q1_max=length(q1);
% q2_max=length(q2);
% q3_max=length(q3);
% q4_max=length(q4);
% q5_max=length(q5);
% q6_max=length(q6);
% pw_ed=zeros(3,q1_max*q2_max*q3_max*q4_max*q5_max*q6_max)';
% pw_eu=zeros(3,q1_max*q2_max*q3_max*q4_max*q5_max*q6_max)';
% count=0;
% for i=1:q1_max
%     for j=1:q2_max
%         for z=1:q3_max
%             for a=1:q4_max
%                 for b=1:q5_max
%                     for c=1:q6_max
%                         if(q6(c)<pi/2)
%                             pw_ed(c+q6_max*count,:)=dk06(q1(i),q2(j),q3(z),q4(a),q5(b),q6(c));
%                         else
%                             pw_eu(c+q3_max*count,:)=dk06(q1(i),q2(j),q3(z),q4(a),q5(b),q6(c));
%                         end
%                     end
%                     count=count+1;
%                 end
%             end
%         end
%     end
% end
% figure(2)
% plot3(pw_ed(:,1),pw_ed(:,2),pw_ed(:,3))
% title({'SPAZIO DI LAVORO';'Manipolatore antropomorfo con polso sferico (6DOF)'})
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% grid
% figure(3)
% plot3(pw_eu(:,1),pw_eu(:,2),pw_eu(:,3))
% title({'SPAZIO DI LAVORO';'Manipolatore antropomorfo con polso sferico (6DOF)'})
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% grid
