using Godot;
using System;

public partial class Enemy : CharacterBody2D
{
    public Player _player;
    private int _hp = 1;
    private int _speed = 5;

    [Export]
    private NodePath _polygon2DPath;
    private Polygon2D _shape;

    [Export]
    private NodePath _progBarContainerPath;
    private Node2D _progBarContainer;

    [Export]
    private NodePath _lifeBarPath;
    private GenericBar _lifeBar;

    public static int Count = 0;
    private Vector2 _startPos;

    [Signal]
    public delegate void EnemyKilledEventHandler();
    
    [Signal]
    public delegate void EnemiesAllDeadEventHandler();

    public override void _Ready()
    {
        GD.Randomize();
        _player = GetNode<Player>("/root/world/Player");
        //_player.Connect("player_died", this, nameof(PlayerDied));
        _player.PlayerDied += PlayerDied;

        // Load nodes
        _shape = GetNode<Polygon2D>(_polygon2DPath);
        _progBarContainer = GetNode<Node2D>(_progBarContainerPath);
        _lifeBar = GetNode<GenericBar>(_lifeBarPath);

        _startPos = Position;

        Reset();
    }

    public override void _Process(double delta)
    {
        var direction = (_player.Position - Position).Normalized() * _speed;

        LookAt(_player.Position);

        var collision = MoveAndCollide(direction);

        // Prevent the bar from rotating
        _progBarContainer.Rotation = -GlobalRotation;
    }

    private void OnArea2DAreaEntered(Area2D area)
    {
        var areaName = area.GetParent().Name.ToString();

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
            _hp = (int)(GD.Randi() % 6 + 1);
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
                GetNode<Sprite2D>("MeGustaSmall").Visible = true;
                _shape.Visible = false;
                Scale = new Vector2(2, 2);
                break;
        }

        _lifeBar.MaxValue = _hp;
        _lifeBar.Value = _hp;
    }
}
