#!/usr/bin/env ruby

#REf 
# http://www.math.ucla.edu/~gschaeff/crypto/RSAAttacks.pdf
# http://crypto.stanford.edu/~dabo/papers/RSA-survey.pdf
# http://hacktracking.blogspot.tw/2014/10/wieners-attack-against-rsa-small-values.html

class WienerExp
  def initialize(n, e)
    @N = n.to_i
    @E = e.to_i
  end

  def exploit
    pq = partial_quotiens(@E, @N)
    c = convergents(pq)
      #REASON
      #(x-p)(x-q) = x**2 - (p+q)x + pq
      #phi(N) = N-p-q+1 
      #since ed - kphi(N) = 1
      #so p+q = N - phi(N) + 1 = N - (ed-1)/k + 1
      #(x-p)(x-q) = x**2 - (p+q)x + pq  = x**2 - (N-(ed-1)/k+1)x + N
    c.each do |v|
      d, k = v[0], v[1]
      p, q = solve_quartic(1, -(@N-(((@E*d)-1)/k)+1), @N) if ! k.zero?

      p, q = q, p if p.to_i < q.to_i
      return p,q if @N == p.to_i*q.to_i
    end
    return nil, nil
  
  end

private 
  def solve_quartic(a, b, c)
    return nil if SqrtInt.is_square(b**2-4*a*c) == false
    p = (-b + SqrtInt.sqrt(b**2-4*a*c))/(2*a)
    q = (-b - SqrtInt.sqrt(b**2-4*a*c))/(2*a)
    return p, q
  end

  def partial_quotiens(x, y)
    pq = []
    until x == 1
      pq << (x/y)
      x, y = y, (x%y)
    end
    return pq
  end

  def convergents(pq)
    c = []
    (0..pq.length-1).each do |i|
      c << rational(pq[0..i])
    end
    return c
  end

  def rational(pq)
    divend = 1
    divser = 0
    pq.reverse.each do |v|
      divser += (divend*v)
      divser, divend = divend, divser
    end
    return [divser, divend]
  end
end

class SqrtInt
  #REF http://stackoverflow.com/questions/15529205/ruby-sqrt-on-a-very-large-integer-cause-rounding-issues
  def self.sqrt a
    begv = 1
    endv = a
    while endv > begv + 1
       mid = (endv + begv)/2
       if mid ** 2 <= a
          begv = mid
       else
          endv = mid
       end
    end
    return begv
  end

  def self.is_square a
    return sqrt(a)**2 == a
  end
end

#p, q =  WienerExp.new(n, e).exploit
