import gymnasium as gym
import craftium



# Worked 
# env = gym.make(
#     "Craftium/SpidersAttack-v0",
#     run_dir_prefix="/tmp/craftium_sync_test"
# )

# Didn't work
env = gym.make(
    "Craftium/SpiderAttackEasy-v0",
    # minetest_dir="/home/upf/data/projects/craftium",
    run_dir_prefix="/tmp/craftium_sync_test"
)

num_episodes = 5
for episode in range(num_episodes):
    obs, info = env.reset()
    total_reward = 0
    steps = 0
    terminated = False
    truncated = False

    print(f"\n=== Episode {episode + 1} ===")

    while not terminated and not truncated:
        action = env.action_space.sample()
        obs, reward, terminated, truncated, info = env.step(action)
        total_reward += reward
        steps += 1

        if reward != 0:
            print(f"Step {steps}: reward = {reward}")

    print(f"Episode {episode + 1} finished after {steps} steps")
    print(f"Total reward: {total_reward}")
    if total_reward > 0:
        print("Result: Player killed the spider!")
    elif total_reward < 0:
        print("Result: Spider killed the player!")
    else:
        print("Result: Timeout (no one died)")

env.close()
print("\nTest completed!")
