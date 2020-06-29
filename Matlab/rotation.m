function [axis1 axis2]=rotation(N,E,Z,baz)

       %ZRT Rotation
                           
       rot=baz-180;  
       R=N.*cosd(rot)+E.*sind(rot);
       TD=-N.*sind(rot)+E.*cosd(rot);   %T_Data
       axis1=R;
       axis2=TD;

        
end
    
