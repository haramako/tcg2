class Array
  def shuffle(rand = Random)
    self.clone.shuffle!(rand)
  end

  def shuffle!(rand = Random)
    len = self.size
    len.times do |n|
      idx = rand.rand(self.size - n)
      self[idx], self[len - n - 1] = self[len - n - 1], self[idx]
    end
    self
  end
end
