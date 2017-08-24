function y = colorShort2Long(shortName)
% colorlongNametor = colorShort2Long(['b' 'k' 'y' 'm' 'c' 'r' 'g' 'w'])
%
% converts color abbreviaton to long name

    

        switch char(shortName)
            case 'y'
                longName = 'yellow';
            case 'm'
                longName = 'magenta';
            case 'c'
                longName = 'cyan';
            case 'r'
                longName = 'red';
            case 'g'
                longName = 'green';
            case 'b'
                longName = 'blue';
            case 'w'
                longName = 'white';
            case 'k'
                longName = 'black';
            otherwise
                error('Abbreviation must be on of the following: ''b'' ''k'' ''y'' ''m'' ''c'' ''r'' ''g'' ''w''');
                
        end

    y = longName;
end