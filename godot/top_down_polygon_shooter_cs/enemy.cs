using Godot;
using System;

public partial class Enemy : CharacterBody2D
{
    public Player Player;
    private int _hp = 1;
    private int _speed = 5;

    [Export]
    private NodePath _polygon2DPath;
    private Polygon2D _shape;

    [Export]
    private NodePath _progBarContainerPath;
    private Node _progBarContainer;

    [Export]
    private NodePath _lifeBarPath;
    private GenericBar _lifeBar;

    public static int Count = 0;
    private Vector2 _startPos;

    [Signal]
    public delegate void EnemyKilled();
    
    [Signal]
    public delegate void EnemiesAllDead();

    public override void _Ready()
    {
        GD.Randomize();
        Player = GetNode<Player>("/root/world/Player");
        Player.Connect("player_died", this, nameof(PlayerDied));

        // Load nodes
        _shape = GetNode<Polygon2D>(_polygon2DPath);
        _progBarContainer = GetNode<Node>(_progBarContainerPath);
        _lifeBar = GetNode<GenericBar>(_lifeBarPath);

        _startPos = Position;

        Reset();
    }

    public override void _Process(float delta)
    {
        var direction = (Player.Position - Position).Normalized() * _speed;

        LookAt(Player.Position);

        var collision = MoveAndCollide(direction);

        // Prevent the bar from rotating
        _progBarContainer.Rotation = -GlobalRotation;
    }

    private void OnArea2DAreaEntered(Area2D area)
    {
        var areaName = area.GetParent().Name;

        if (areaName.Contains("Bullet") || areaName.Contains("RigidBody2D"))
        {
            _hp -= 1;
            _lifeBar.UpdateValue(_hp, null);
            GD.Print(_hp);
            if (_hp <= 0)
            {
                Count -= 1;
                EmitSignal(nameof(EnemyKilled));

                GetTree().CallGroup("game_manager", "add_kill");
                GD.Print("Enemies left: " + Count);

                area.GetParent().QueueFree();
                QueueFree();

                if (Count <= 0)
                {
                    EmitSignal(nameof(EnemiesAllDead));
                    GetTree().CallGroup("game_manager", "start_spawning");
                }
            }
        }
    }

    public void PlayerDied()
    {
        Count = 0;
    }

    public void Reset()
    {
        Count += 1;

        if (Count > 5)
        {
            _hp = GD.Randi() % 6 + 1;
        }

        switch (_hp)
        {
            case 1:
                _shape.Color = new Color(1, 1, 1);
                break;
            case 2:
            case 3:
                _shape.Color = new Color(0, 0.8f, 0);
                break;
            case 4:
                _shape.Color = new Color(0, 0, 0.8f);
                break;
            case 5:
                _shape.Color = new Color(0.8f, 0, 0);
                Scale = new Vector2(1.5f, 1.5f);
                break;
            case 6:
                GetNode<Sprite>("MeGustaSmall").Visible = true;
                _shape.Visible = false;
                Scale = new Vector2(2, 2);
                break;
        }

        _lifeBar.MaxValue = _hp;
        _lifeBar.Value = _hp;
    }
}
