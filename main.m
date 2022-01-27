n = 100;
t_0 = zeros(n, n);
t_1 = randi([0 1], n, n);
pause('on');

while (true)
        
    [t_0, t_1] = update_state(t_0, t_1, n);
    display(n, t_1);
        
end



function display(n, C)
    x = [0 n];
    y = [0 n];
    image(x, y, C .* 255)
    drawnow
    pause(0.03);
end


function poblation = get_poblation(t, i, j, n)

    poblation = 0;
    for i_inner = i-1:i+1
        for j_inner = j-1:j+1
            poblation = poblation + t(mod(i_inner - 1, n) + 1 , mod(j_inner - 1, n) + 1);
        end
    end
end


function [t_0, t_1] = update_state(t_0, t_1, n)
    for i = 1:n
        for j = 1:n
            poblation = get_poblation(t_1, i + n, j + n, n) - t_1(i, j);
            
            if (t_1(i, j) == 0)
               if (poblation == 3) 
                    t_0(i, j) = 1;
               end
            else
                if (poblation ~= 2 && poblation ~= 3)
                    t_0(i, j) = 0;
                end
            end
        end
    end
    t_1 = t_0;
end
