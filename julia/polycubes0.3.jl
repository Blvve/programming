function polycube_iterator(n, stack, attachments, f)
	if length(stack) == n
		f(stack)
	else
		Threads.@threads for i in last(attachments):length(stack)
			Threads.@threads for next in neighbours(stack, attachments, i)
				new_stack = copy(stack)
				new_attachments = copy(attachments)
				push!(new_stack, next)
				push!(new_attachments, i)
				polycube_iterator(n, new_stack, new_attachments, f)
			end
		end
	end
end

polycube_iterator(n, stack, f) = polycube_iterator(n, stack, [1], f)

function neighbours(stack, attachments, i)
	deltas = [[-1, 0, 0], [0, -1, 0], [0, 0, -1], [0, 0, 1], [0, 1, 0], [1, 0, 0]]
	nghbrs = [j + stack[i] for j in deltas]

	trunk = first(stack, i-1)
	bark = []
	for v in trunk, d in deltas
		push!(bark, v+d)
	end # things that are adjacent to something before stack[i]

	prev_branches = [stack[k] for k in findall(isequal(i), attachments)]

	start_after = prev_branches != [] ? last(prev_branches) : stack[1] # cubes before this are forbidden by the choice of root or by the previous branches

	# remove forbidden neighbours
	for j in length(nghbrs):-1:1
		(
		(nghbrs[j] in stack) # covered by another cube
		|| (nghbrs[j] <= start_after) # before root or before some other branch of stack[i]
		|| (nghbrs[j] in bark) # these would have been attached to an earlier cube
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


function deal_with_it(stack)
	syms = symmetries(stack)
	Threads.atomic_add!(total24, symmetries(stack))
end

total24 = Threads.Atomic{Int}(0)
# totalsyms = zeros(Int64, 24)

for n in 1:12
	root = [0, 0, 0]
	stack = [root]
	Threads.atomic_xchg!(total24, 0)
	# global totalsyms = zeros(Int64, 24)
	polycube_iterator(n, stack, deal_with_it)
	println("With $n there are a total of ", total24[]/24)
end

