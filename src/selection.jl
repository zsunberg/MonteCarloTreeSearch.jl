struct MaxUCB <: Function
    c::Float64
end

function (mu::MaxUCB)(n::StateNode)
    bestucb = -Inf
    best = first(children(n))
    tn = totaln(n)
    for sanode in children(n)
        if c == 0 || tn == 0 || (tn == 1 && n(sanode) == 0)
            ucb = q(sanode)
        else
            ucb = q(sanode) + c*sqrt(log(tn)/n(sanode))
        end
        @assert !isnan(ucb)
        @assert !isequal(ucb, -Inf)
        if ucb > bestucb
            bestucb = ucb
            best = sanode
        end
    end
    return best
end

maxtried(n::StateNode) = reduce(children(n)) do an1, an2
    if n(an1) > n(an2)
        return an1
    else
        return an2
    end
end
