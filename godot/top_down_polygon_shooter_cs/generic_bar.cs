using Godot;
using System;

public partial class GenericBar : ProgressBar
{
    [Export]
    public string BarName { get; set; }

    private bool _showText = true;
    [Export]
    public bool ShowText
    {
        get => _showText;
        set
        {
            _showText = value;
            if (_text != null)
            {
                _text.Visible = _showText;
            }
        }
    }

    private Label _text;

    public override void _Ready()
    {
        _text = GetNode<Label>("BarText");
        _text.Visible = ShowText;
    }

    public void UpdateValue(int newValue, int? max = null)
    {
        if (max.HasValue)
        {
            MaxValue = max.Value;
        }
        Value = newValue;
    }
}
