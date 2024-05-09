using Godot;
using System;

public partial class Bullet : RigidBody2D
{
    private string _realName = "";

    // This function is called when the timer times out
    private void OnTimerTimeout()
    {
        QueueFree(); // This method will free the node
    }
}
