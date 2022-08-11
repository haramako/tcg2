using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using MRuby;
using UnityEngine.EventSystems;
using TMPro;

[CustomMRubyClass]
public class TextBlock : BoardObject
{
    public TMP_Text Model;

    public void Redraw(string text)
    {
        Model.text = text;
    }
}
