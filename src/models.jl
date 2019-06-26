# [ ] How to support states, actions, etc.
# [ ] initial state distributions??
#
# Things that make this unnecessarily complicated for MCTS
# [ ] rng
# [ ] isterminal

struct StepFunctionMDP{S,A,F,G,I,T}
    step::F
    actions::G
    initialstate::I
    discount::Float64
    isterminal::T
end

StepFunctionMDP(step, actions, initialstate, discount, isterminal=s->false)

POMDPs.generate_sri(m::StepFunctionMDP, s, a, rng) = m.step(s, a, rng)
POMDPs.generate_sr(m::StepFunctionMDP, s, a, rng) = m.step(s, a, rng)[1:2]
POMDPs.generate_s(m::StepFunctionMDP, s, a, rng) = m.step(s, a, rng)[1]

POMDPs.actions(m::StepFunctionMDP, s) = m.actions(s)

POMDPs.discount(m::StepFunctionMDP) = m.discount
POMDPs.initialstate(m::StepFunctionMDP, rng) = m.initialstate(rng)
POMDPs.isterminal(m::StepFunctionMDP, s) = m.isterminal(s)
