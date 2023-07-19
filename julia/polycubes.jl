n = 7
x1, x2, x3 = n, (n+1)÷2, (n+2)÷3
volume = x1*x2*x3
total = 0
to_count = factorial(big(volume))/(factorial(n)*factorial(big(volume - n)))
println(to_count)

function rset_iterator(v, r, f)
	if r == 0
		f(v)
	else
		first = findfirst(isequal(1), v)
		first = first == nothing ? length(v)+1 : first
		for i=first-1:-1:r
			v[i] = 1
			rset_iterator(v, r-1, f)
			v[i] = 0
		end
	end
end




function bfs(b, i, j, k)
	b[i, j, k] = 0
	count = 1
	i > 1  && b[i-1, j, k] == 1 && (count += bfs(b, i-1, j, k))
	i < x1 && b[i+1, j, k] == 1 && (count += bfs(b, i+1, j, k))
	j > 1  && b[i, j-1, k] == 1 && (count += bfs(b, i, j-1, k))
	j < x2 && b[i, j+1, k] == 1 && (count += bfs(b, i, j+1, k))
	k > 1  && b[i, j, k-1] == 1 && (count += bfs(b, i, j, k-1))
	k < x3 && b[i, j, k+1] == 1 && (count += bfs(b, i, j, k+1))
	return count
end

function isconnected(b)
	for i=1:x1, j=1:x2, k=1:x3
		if b[i, j, k] == 1
			return n == bfs(copy(b), i, j, k)
			break
		end
	end
end

function isoriented(b)
	return true
end

boxify(v) = [v[i+(j-1)*x1+(k-1)*x1*x2] for i=1:x1, j=1:x2, k=1:x3]

function count_good_polycubes(v)
	b = boxify(v)
	global total += isconnected(b) && isoriented(b) ? 1 : 0
	println(total)
end

vbox = zeros(Int8, volume)
rset_iterator(vbox, n, count_good_polycubes)
println(total)
