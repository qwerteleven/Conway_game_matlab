n = 1000;
t = randi([0 1], n, n);
pause('on');

mask = [1 1 1; 1 0 1; 1 1 1];


while (true)
        
    t = update_state(t, n, mask);
    display(n, t);
end



function display(n, C)
    x = [0 n];
    y = [0 n];
    image(x, y, C .* 255)
    drawnow
end



function t = update_state(t, n, mask)
    poblations = conv2(t, mask, 'valid');
    
    for i = 2:n-1
        for j = 2:n-1
            if (t(i, j) == 0)
               if (poblations(i - 1, j - 1) == 3) 
                    t(i, j) = 1;
               end
            else
                if (poblations(i - 1, j - 1) ~= 2 && poblations(i - 1, j - 1) ~= 3)
                    t(i, j) = 0;
                end
            end
        end
    end
end

