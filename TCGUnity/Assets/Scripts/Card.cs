using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using MRuby;
using UnityEngine.EventSystems;
using System.Linq;
using DG.Tweening;

[CustomMRubyClass]
public class Card : BoardObject
{
    //public Text NameText;
    //public Button Button;
    //public Image Image;
    //public Image CardImage;
    public MeshRenderer CardPlane;
    public MeshRenderer ReversePlane;
    private Material material;
    private Material reverseMaterial;

    public void Redraw(string name, bool selected)
    {
        //NameText.text = name;
#if false
        Image.color = selected ? new Color(1.0f, 0.7f, 0.7f) : Color.white;
#endif

        var rect = getTextureRect(name);
        material.mainTextureOffset = new Vector2(rect.x, rect.y);
        material.mainTextureScale = new Vector2(rect.width, rect.height);
    }

    public void Awake()
    {
        material = Instantiate<Material>(CardPlane.material);
        CardPlane.material = material;

        reverseMaterial = Instantiate<Material>(ReversePlane.material);
        ReversePlane.material = reverseMaterial;

        var rect = getTextureRect("J");
        reverseMaterial.mainTextureOffset = new Vector2(rect.x, rect.y);
        reverseMaterial.mainTextureScale = new Vector2(rect.width, rect.height);
    }

    public void OnClick()
    {
        var selectable = MainScene.Instance.Game.x("selectable?", ObjectID).AsBool();
        if (selectable)
        {
            MainScene.Instance.Play(new Command("select") { Card = ObjectID });
        }
    }

    Rect getTextureRect(string name)
    {
        var atlas = MainScene.Instance.CardAtlas;
        //spade,dia,heard,club
        //j = 52,53
        //— =54~
        int idx;
        if (name != "J")
        {
            var suit = name[0];
            var num = name.Substring(1);
            int numNum = 0;
            int suitNum = 0;
            switch (num)
            {
                case "1":
                case "2":
                case "3":
                case "4":
                case "5":
                case "6":
                case "7":
                case "8":
                case "9":
                case "10":
                    numNum = int.Parse(num);
                    break;
                case "J":
                    numNum = 11;
                    break;
                case "Q":
                    numNum = 12;
                    break;
                case "K":
                    numNum = 13;
                    break;
                default:
                    throw new System.Exception();
            }
            switch (suit)
            {
                case 'S':
                    suitNum = 0;
                    break;
                case 'D':
                    suitNum = 1;
                    break;
                case 'H':
                    suitNum = 2;
                    break;
                case 'C':
                    suitNum = 3;
                    break;
                default:
                    throw new System.Exception();
            }
            idx = suitNum * 13 + numNum - 1;
        }
        else
        {
            idx = 54;
        }

        float x = idx % 10;
        float y = idx / 10;

        float u = x * (204 / 2048.0f);
        float v = 1.0f - (y + 1) * (288 / 2048.0f);
        float w = 204 / 2048.0f;
        float h = 288 / 2048.0f;
        return new Rect(u, v, w, h);
    }
}
