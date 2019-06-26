module MonteCarloTreeSearch

@with_kw struct ExpectimaxOptions{S<:Function,V<:Function,Q<:Function,N<:Function,SA<:Function,R<:AbstractRNG}
    iterations::Int64   = 100
    maxdepth::Int64     = typemax(Int)
    rng::R              = Random.GLOBAL_RNG
    select::S           = MaxUCB(1.0)
    leafvalue::V        = RandomRollout(rng)
    initq::Q            = (m, s, a)->0.0
    initn::N            = (m, s, a)->0
    selectaction::SA    = maxtried
    keepstats::Bool     = false
end

inittree(options, model, state) = ExpectimaxTree{statetype(model), actiontype(model)}(options.iterations)

function simulate!(tree::ExpectimaxTree,
                   opt::ExpectimaxOptions,
                   m::MDP,
                   n::StateNode,
                   stepstogo::Int)

    # once depth is zero return
    if stepstogo == 0 || isterminal(m, state(node))
        return 0.0
    end

    # pick action
    sanode = opt.select(n)
    said = sanode.id

    # transition to a new state
    sp, r = generate_sr(m, state(n), action(sanode), rng)
    
    spid = get(tree.statemap, sp, 0)
    if spid == 0
        spn = insertnode!(tree, planner, sp)
        spid = spn.id
        q = r + discount(mdp) * opt.leafvalue(m, sp, stepstogo-1)
    else
        q = r + discount(mdp) * simulate!(tree, opt, m, StateNode(tree, spid), stepstogo-1)
    end

    if opt.keepstats
        recordvisit!(tree, said, spid)
    end

    tree.totaln[n.id] += 1
    tree.n[said] += 1
    tree.q[said] += (q - tree.q[said]) / tree.n[said] # moving average of Q value
    return q
end

maketree(options, model, state)

search(options, model, state)


struct RandomRollout{R<:AbstractRNG}
    rng::R
end

function (rr::RandomRollout)(m, s, stepstogo)
    sim = RolloutSimulator(rr.rng, stepstogo)
    policy = RandomPolicy(rr.rng, m, NothingUpdater())
    return POMDPs.simulate(sim, mdp, policy, s)
end

end # module
