 flag = 0; %to designate package recieved
    %wait for packages
     while (flag ~= 1)

       if (numel()>0)
           t1=0;  cx1=cx1+1; 


           flag = 1; % mark that we have a package
       else

          t1=t1+1.2;
          if (t1>4), fprintf('Too much time not having activity...\n');   
              break  
          end %timeout

       end   

        if (toc()>1)   % print, at ~1HZ
            tic();  cx2=cx2+cx1; 
            if (cx1>0) 
                fprintf('Messages: new=[%d],total=[%d]\n',cx1,cx2);
            else
                fprintf('Messages: NO new arrivals.\n');
            end

            cx1=0;
        end  

    end