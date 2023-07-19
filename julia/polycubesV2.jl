function polycube_iterator(n, stack, attachements, f)
	if length(stack) == n
		f(stack)
	else
		for i in last(attachements):length(stack)
			for next in neighbours(stack, attachements, i)
				push!(stack, next)
				push!(attachements, i)
				polycube_iterator(n, stack, attachements, f)
				pop!(stack)
				pop!(attachements)
			end
		end
	end
end

polycube_iterator(n, stack, f) = polycube_iterator(n, stack, [1], f)

function neighbours(stack, attachements, i)
	deltas = [[-1, 0, 0], [0, -1, 0], [0, 0, -1], [0, 0, 1], [0, 1, 0], [1, 0, 0]]
	nghbrs = [j + stack[i] for j in deltas]

	trunc = first(stack, i-1)
	barc = []
	for v in trunc, d in deltas
		push!(barc, v+d)
	end # things that are adjacent to something before stack[i]

	prev_branches = last(stack, length(stack)-i)

	start_after = prev_branches != [] ? last(prev_branches) : stack[1] # cubes before this are forbidden by the choice of root or by the previous branches

	# remove forbidden neighbours
	for j in length(nghbrs):-1:1
		(
		(nghbrs[j] == stack[attachements[i]]) # covered by the attachement of stack[i]
		|| (nghbrs[j] <= start_after) # before root or before some other branch of stack[i]
		|| (nghbrs[j] in barc) # these would have been attached to an earlier cube
		) && (deleteat!(nghbrs, j))
	end
	return nghbrs
end

L = [[0, 1, 0] [-1, 0, 0] [0, 0, 1]]
U = [[1, 0, 0] [0, 0, -1] [0, 1, 0]]
I = [[1, 0, 0] [0, 1, 0] [0, 0, 1]]

rotations = [I, L, L^2, L^3,
	     U, U*L, U*L^2, U*L^3,
	     U^2, U^2*L, U^2*L^2, U^2*L^3,
	     U^3, U^3*L, U^3*L^2, U^3*L^3,
	     L*U, L*U*L, L*U*L^2, L*U*L^3,
	     L*U^3, L*U^3*L, L*U^3*L^2, L*U^3*L^3]

function symmetries(stack)
	rotated = [sort!([M*v for v in stack]) for M in rotations]
	rooted = [[x-s[1] for x in s] for s in rotated]
	syms = length(findall(x -> x==rooted[1], rooted))
	return syms
end


root = [0, 0, 0]
stack = [root]
total24 = 0
function info(stack)
	# println(stack)
	# println(symmetries(stack))
	global total24 += symmetries(stack)
	# syms = symmetries(stack)
	# test = 1
	# (syms == test) && (global total24 += test)
end

polycube_iterator(4, stack, info)
# println(total24)
println(total24/24)
