%
%
%
Tint=input('Enter the interior temperature Tint [C]: ');
Theta=input('Input the thermostat constant Theta [C]: ');
DTint=input('Input the cooling temperature difference DTint [C]: ');
tau_h=input('Input the heating constant tau_h [C/h]: ');
tau_c=input('Input the cooling constant tau_c [C/h]: ');
t_end=input('Input the simulation time [h]: ');
n_h=input('Input the number of homes n_h: '); 
samp=input('Input the sample home index: ');
%
%t_h=Theta*tau_h; t_c=Theta*tau_c; t_p=t_h+t_c;
%
therm(1:n_h)=0;           %  thermostat on/off  
T0(1:n_h)=0;              %  initial temperature
T(1:n_h,1)=0;             %  history temperatures
Tc(1:n_h,1)=0;            %  current temperatures
t_ch=[T0]';               %  history thermostat change times
t_st=zeros(n_h,1);        %  current thermostat change times
n_e=1000*t_end;
E(1:n_e,1)=0; 
P(1:n_e,1)=0;
rng('shuffle','multFibonacci');
therm=randi([0,1],1,n_h);
for i=1:n_h
   T0(i)=Tint+Theta*rand;
   if(T0(i)==Tint && therm(i)==0) 
      therm(i)=1;
   end
   if(T0(i)==Tint+Theta && them(i)==1)
      therm(i)=0;
   end
end
T=T0';
for i=1:n_h
   if(therm(i)==0)   %  the home is cooling down
      t_st(i,1)=(T0(i)-Tint)/tau_c; therm(i)=1;
      Tc(i,1)=Tint;
   else   %  the home is heating up
      t_st(i,1)=(Tint+Theta-T0(i))/tau_h; therm(i)=0;
      Tc(i,1)=Tint+Theta;
      n_l=1; n_u=ceil(t_st(i,1)*1000);
      E(n_l:n_u,1)=E(n_l:n_u,1)+1;
   end
end
t_ch=[t_ch,t_st]; T=[T,Tc]; conv=0;
while(conv==0)
   conv=1; 
   for i=1:n_h 
      if(therm(i)==0 && t_st(i,1)<t_end)   %  cooling down next
         t_st(i,1)=t_st(i,1)+Theta/tau_c; 
         Tc(i,1)=Tint;
         if(t_st(i,1)>t_end)
            Tc(i,1)=Tc(i,1)+(t_st(i,1)-t_end)*tau_c; 
            t_st(i,1)=t_end;  
         end
      end
      if(therm(i)==1 && t_st(i,1)<t_end)   %  heating up next
         n_l=floor(t_st(i,1)*1000); 
         t_st(i,1)=t_st(i,1)+Theta/tau_h; 
         Tc(i,1)=Tint+Theta;
         if(t_st(i,1)>t_end)
            Tc(i,1)=Tc(i,1)-(t_st(i,1)-t_end)*tau_h;
            t_st(i,1)=t_end; 
         end
         n_u=ceil(t_st(i,1)*1000);
         E(n_l:n_u,1)=E(n_l:n_u,1)+1;
      end
      if(therm(i)==0) 
         therm(i)=1;
      else
         therm(i)=0;
      end
      if(t_st(i,1)<t_end)
         conv=0;
      end
   end
   t_ch=[t_ch,t_st]; T=[T,Tc];
end
for i=1:n_e
   if(i>1) 
      P(i)=P(i-1)+0.001*E(i); 
   else
      P(i)=0.001*E(i);
   end
end
set(gcf,'Position',[10,530,1260,400]);
if(samp>=1 && samp<=n_h)
   n_s=1; 
   while(t_ch(samp,n_s)<t_end)
      n_s=n_s+1;
   end
   for i=1:n_s-1
      subplot(131); 
      plot([t_ch(samp,i) t_ch(samp,i+1)],[T(samp,i) T(samp,i+1)],'-b','LineWidth',2); hold on 
   end
   axis([0 t_end Tint-1 Tint+Theta+1]);
   xlabel('time [h]'); ylabel('Temp [^\circ C]');
   title(['Temperature profile of the home ',num2str(samp)]);
   x=[0:0.01:t_end]; nx=size(x);
   y1(1:nx(1))=Tint; y2(1:nx(1))=Tint+Theta;
   plot(x,y1,'-k','LineWidth',1);
   hold on
   plot(x,y2,'-k','LineWidth',1);
end
subplot(132); plot(E,'-r','LineWidth',1.5);
axis([0 n_e 0.9*min(E) 1.1*max(E)]);
xlabel('time [h/10^3]'); ylabel('Number of heated homes');
title('Current power consumption (1=one home heated)')
subplot(133); plot(P,'-g','LineWidth',1.5);
axis([0 n_e 0.9*min(P) 1.1*max(P)]);
xlabel('time [h/10^3]'); ylabel('Cummulative power');
title('Cummulative power consumption [homes heated * hours]');

