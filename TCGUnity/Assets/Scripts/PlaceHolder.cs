using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using MRuby;
using UnityEngine.EventSystems;

[CustomMRubyClass]
public class PlaceHolder : BoardObject
{
    public void Redraw(string name, bool selected)
    {
        //NameText.text = name;
        //Image.color = selected ? new Color(1.0f, 0.7f, 0.7f) : Color.white;
    }

}
