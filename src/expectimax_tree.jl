# eventually there might be something like AbstractMCTSTree

abstract type AbstractExpectimaxTree{S,A} end

struct StateNode{T<:AbstractExpectimaxTree}
    tree::T
    id::Int
end
StateNode(tree::AbstractExpectimaxTree{S}, s::S) where S = StateNode(tree, tree.statemap[s])

# accessors for state nodes
state(n::StateNode) = n.tree.slabels[n.id]
totaln(n::StateNode) = n.tree.totaln[n.id]
child_ids(n::StateNode) = n.tree.child_ids[n.id]
children(n::StateNode) = (ActionNode(n.tree, id) for id in child_ids(n))

struct ActionNode{T<:AbstractExpectimaxTree}
    tree::T
    id::Int
end

# accessors for action nodes
POMDPs.action(n::ActionNode) = n.tree.alabels[n.id]
n(n::ActionNode) = n.tree.n[n.id]
q(n::ActionNode) = n.tree.q[n.id]

mutable struct ExpectimaxTree{S,A} <: AbstractExpectimaxTree{S,A}
    statemap::Dict{S,Int}

    # these vectors have one entry for each state node
    child_ids::Vector{Vector{Int}}
    totaln::Vector{Int}
    slabels::Vector{S}

    # these vectors have one entry for each action node
    n::Vector{Int}
    q::Vector{Float64}
    alabels::Vector{A}

    visstats::Union{Nothing, Dict{Pair{Int,Int}, Int}} # maps (said=>sid)=>number of transitions.

    function MCTSTree{S,A}(sz::Int=1000) where {S,A}
        sz = min(sz, 100_000)

        return new(Dict{S, Int}(),

                   sizehint!(Vector{Int}[], sz),
                   sizehint!(Int[], sz),
                   sizehint!(S[], sz),

                   sizehint!(Int[], sz),
                   sizehint!(Float64[], sz),
                   sizehint!(A[], sz),
                   Dict{Pair{Int,Int},Int}()
                  )
    end
end

Base.isempty(t::ExpectimaxTree) = isempty(t.statemap)
statenodes(t::ExpectimaxTree) = (StateNode(t, id) for id in 1:length(t.totaln))

function insertnode!(tree::ExpectimaxTree,
                      opt::ExpectimaxOptions,
                      m::MDP
                      s)

    push!(tree.slabels, s)
    tree.statemap[s] = length(tree.slabels)
    push!(tree.child_ids, Int[])
    totaln = 0
    for a in actions(m, s)
        n = opt.initn(m, s, a)
        totaln += n
        push!(tree.n, n)
        push!(tree.q, opt.initq(m, s, a))
        push!(tree.alabels, a)
        push!(last(tree.child_ids), length(tree.n))
    end
    push!(tree.totaln, totaln)
    return StateNode(tree, length(tree.totaln))
end
