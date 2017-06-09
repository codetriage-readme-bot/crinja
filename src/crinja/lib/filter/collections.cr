module Crinja::Filter
  Crinja.filter :list do
    value = target.raw

    case value
    when String
      value.chars.map(&.to_s.as(Type))
    when Array
      value
    when .responds_to?(:to_a)
      value.to_a
    else
      raise TypeError.new("target for list filter cannot be converted to list")
    end
  end

  Crinja.filter({linecount: 2, fill_with: nil}, :batch) do
    value = target.raw
    fill_with = arguments[:fill_with].raw
    linecount = arguments[:linecount].to_i

    case value
    when Array
      array = Array(Type).new

      value.each_slice(linecount) do |slice|
        (linecount - slice.size).times { slice << fill_with } unless fill_with.nil?
        array << slice
      end

      array
    else
      raise TypeError.new("target for batch filter must be a list")
    end
  end

  Crinja.filter({slices: 2, fill_with: nil}, :slice) do
    fill_with = arguments[:fill_with].raw
    slices = arguments[:slices].to_i
    raw = target.raw

    case raw
    when Array(Type)
      values = [] of Type
      raw.each do |val|
        values << val.as(Type)
      end
      array = Array(Type).new

      num_full_slices = values.size % slices
      per_slice = values.size / slices

      num_full_slices.times do |i|
        slice = Array(Type).new
        values[i * (per_slice + 1), per_slice + 1].each do |v|
          slice << v.as(Type)
        end
        array << slice
      end

      (slices - num_full_slices).times do |i|
        slice = values[(num_full_slices + i) * per_slice + num_full_slices, per_slice]
        slice << fill_with unless fill_with.nil?
        array << slice
      end

      array
    else
      raise TypeError.new("target for batch filter must be a list")
    end
  end

  Crinja.filter(:first) { target.first.raw }
  Crinja.filter(:last) { target.last.raw }
  Crinja.filter(:length) { target.size }

  Crinja.filter(:reverse) do
    reversable = target.raw
    if reversable.responds_to?(:reverse_each)
      reversable.reverse_each
    elsif reversable.responds_to?(:reverse)
      reversable.reverse
    else
      raise TypeError.new(target, "#{target.raw.class} cannot be reversed")
    end
  end
end