function y = handleErrors(functionName, ip)

    switch functionName
        case 'crossValidateMulti'
            if ip.Results.nFolds == 1
                % Special case of fitting model with no test set (argh)
                error('nFolds must be a integer value greater than 1');
            end

        case 'crossValidatePairs'

        case 'crossValidateMulti_opt'

        case 'crossValidatePairs_opt'

        case 'trainMulti'

        case 'trainPairs'

        case 'trainPairs_opt'

        case 'trainMulti_opt'

        otherwise

    end


end