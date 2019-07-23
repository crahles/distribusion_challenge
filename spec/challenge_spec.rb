describe Challenge, :vcr do
  it '#new' do
    expect { Challenge.new }.not_to raise_error
  end
end
