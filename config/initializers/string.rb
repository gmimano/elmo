class String
  def is_number?
    true if Float(self) rescue false
  end
  def normalize
    mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'')
  end
  def ucwords
    self.split(" ").map{|w| w.capitalize}.join(" ")
  end
end