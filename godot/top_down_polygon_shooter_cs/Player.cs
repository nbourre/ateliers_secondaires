using Godot;
using System;

public partial class Player : CharacterBody2D
{
    [Signal]
    public delegate void PlayerDied();

    [Export]
    public int Speed = 1000;
    [Export]
    public float Acceleration = 0.1f;
    [Export]
    public float Friction = 0.05f;

    private Vector2 _direction = new Vector2();
    // TODO: Add a timer to the game
    private int _bulletSpeed = 1000;
    private PackedScene _bullet = (PackedScene)ResourceLoader.Load("res://Bullet.tscn");

    public override void _PhysicsProcess(float delta)
    {
        _direction.x = Input.GetActionStrength("right") - Input.GetActionStrength("left");
        _direction.y = Input.GetActionStrength("down") - Input.GetActionStrength("up");

        _direction = _direction.Normalized();

        LookAt(GetGlobalMousePosition());

        if (Input.IsActionJustPressed("fire"))
        {
            Fire();
        }

        if (_direction.Length() > 0)
        {
            Velocity = Velocity.LinearInterpolate(_direction * Speed, Acceleration);
        }
        else
        {
            Velocity = Velocity.LinearInterpolate(Vector2.Zero, Friction);
        }

        MoveAndSlide();
    }

    private void Fire()
    {
        Bullet bulletInstance = (Bullet)_bullet.Instance();
        bulletInstance.Position = GlobalPosition + (Vector2.Right.Rotated(Rotation) * 25);
        bulletInstance.RotationDegrees = RotationDegrees;
        bulletInstance.ApplyImpulse(Vector2.Zero, new Vector2(_bulletSpeed, 0).Rotated(Rotation));
        bulletInstance.RealName = "Bullet";
        GetTree().Root.CallDeferred("add_child", bulletInstance);
    }

    private void OnArea2DAreaEntered(Area2D area)
    {
        if (area.GetParent() is Enemy)
        {
            GetTree().CallDeferred("reload_current_scene");
            EmitSignal(nameof(PlayerDied));
        }
    }
}
