using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MRuby;
using System.Linq;
using DG.Tweening;
using UnityEngine.U2D;
using UnityEngine.UI;
using UnityEngine.InputSystem;
using UnityEngine.UIElements;
using Button = UnityEngine.UI.Button;

[CustomMRubyClass]
public class Command
{
    public readonly string Type;
    public int Card;
    public int MoveTo;

    public Command(string t)
    {
        Type = t;
    }

    public override string ToString()
    {
        return $"{Type} {Card}";
    }

    public string Inspect()
    {
        return ToString();
    }
}

public class MainScene : MonoSingleton<MainScene>
{
    public BoardView View;
    public SpriteAtlas CardAtlas;
    public Button ResetButton;
    public Button StartButton;
    public Button DiscardButton;
    public Button BetButton;
    public Canvas Canvas;
    public UIDocument Doc;

    VM mrb;

    public Value Game { get; private set; }

    public VM Mrb => mrb;

    void Start()
    {
        //initUI();
        run();
    }

    void initUI()
    {
        var li = Doc.rootVisualElement.Q<ListView>("list");
        var source = new string[] { "A", "B", "C" };
        li.itemsSource = source;
        li.makeItem = () => new Label();
        li.bindItem = (v,i) => { ((Label)v).text = source[i]; };
    }

    private void Update()
    {
        if(Keyboard.current.f5Key.wasPressedThisFrame)
        {
            run();
        }
    }

    void run()
    {
        View.Clear();

        var opt = new VMOption()
        {
            LoadPath = new string[] { "../Ruby" },
        };
        mrb = new VM(opt);

        Value r;

        mrb.Run("require 'app'");

        r = mrb.Run("Dummy::DummyRule.new");
        //r = mrb.Run("PokerRule.new");
        Game = r;

        Play(new Command("reset"));
        Play(new Command("start"));
    }

    public Value Play(Command cmd)
    {
        var result = Game.x("play", cmd);
        Game.x("board").x("root").x("redraw_all", View);
        redraw();
        return result;
    }

    void redraw()
    {
        ResetButton.interactable = Game.x("trigger?", "reset").AsBool();
        StartButton.interactable = Game.x("trigger?", "start").AsBool();
        DiscardButton.interactable = Game.x("trigger?", "discard").AsBool();
        BetButton.interactable = Game.x("trigger?", "bet").AsBool();
    }

    public void OnResetClick()
    {
        Play(new Command("reset"));
    }

    public void OnStartClick()
    {
        Play(new Command("start"));
    }

    public void OnDiscardClick()
    {
        Play(new Command("discard"));
    }

    public void OnBetClick()
    {
        var r = Play(new Command("bet"));
        Debug.Log(r.ToString());
    }

}
