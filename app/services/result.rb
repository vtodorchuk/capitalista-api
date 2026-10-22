Result = Data.define(:success, :value, :error) do
  def self.ok(value = nil) = new(success: true, value:, error: nil)
  def self.fail(error)     = new(success: false, value: nil, error:)
  def success? = success
  def failure? = !success
end
