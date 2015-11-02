require 'spec_helper'

describe TeamPlayer do
  it {should belong_to(:team)}
  it {should belong_to(:squad_position)}
end
