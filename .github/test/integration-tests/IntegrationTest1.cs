using core_demo_api;

namespace IntegrationTests
{
    public class IntegrationTest1
    {
        [Fact]
        public void InitColorController_IsNotNull()
        {
            var c = new ColorController();
            Assert.NotNull(c);
            var a = c.GetColor();
            Assert.NotNull(a);
        }
    }
}